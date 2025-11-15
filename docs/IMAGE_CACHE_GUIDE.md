# Guía de Cache de Imágenes

Esta guía explica cómo trabajar con el sistema de cache de imágenes implementado en QuberTaxi, que permite minimizar el consumo de datos mientras maneja inteligentemente las actualizaciones de imágenes.

## Tabla de Contenidos

1. [Visión General](#visión-general)T
2. [Componentes Principales](#componentes-principales)
3. [Uso Básico](#uso-básico)
4. [Invalidación de Cache](#invalidación-de-cache)
5. [Ejemplos Completos](#ejemplos-completos)
6. [Mejores Prácticas](#mejores-prácticas)
7. [Solución de Problemas](#solución-de-problemas)

## Visión General

El sistema de cache de imágenes está diseñado para:

- ✅ **Minimizar consumo de datos**: Las imágenes se cachean en disco y memoria
- ✅ **Manejar actualizaciones inteligentemente**: Invalida el cache solo cuando la imagen realmente cambia
- ✅ **Persistir entre sesiones**: El cache persiste incluso después de cerrar la app
- ✅ **Ser reutilizable**: Un solo servicio puede usarse en cualquier vista

### Cómo Funciona

1. **Cache Key Persistente**: Cada imagen tiene un `cacheKey` único almacenado en SharedPreferences
2. **SmartCachedImage Widget**: Widget que envuelve `CachedNetworkImage` y usa el `cacheKey` para invalidación
3. **ImageCacheManager**: Servicio singleton que gestiona los `cacheKey` y la invalidación del cache

Cuando se actualiza una imagen:
- Se genera un nuevo `cacheKey` (timestamp)
- Se eliminan las entradas de cache antiguas
- Se guarda el nuevo `cacheKey` en SharedPreferences
- El widget se reconstruye con el nuevo `cacheKey`, forzando la descarga de la nueva imagen

## Componentes Principales

### 1. ImageCacheManager

Servicio singleton que gestiona el cache de imágenes.

**Ubicación**: `lib/utils/image/image_cache_manager.dart`

**Métodos principales**:
- `getCacheKey()`: Obtiene o crea un `cacheKey` para una entidad
- `getCacheKeySync()`: Obtiene `cacheKey` de forma síncrona (sin crear si no existe)
- `getOrCreateCacheKeySync()`: Obtiene o crea `cacheKey` de forma síncrona
- `invalidateCache()`: Invalida el cache y crea un nuevo `cacheKey`
- `saveCacheKeyIfNeeded()`: Guarda un `cacheKey` si fue recién creado

### 2. SmartCachedImage

Widget que muestra imágenes de red con cache inteligente.

**Ubicación**: `lib/common/widgets/smart_cached_image.dart`

**Características**:
- Cache en disco y memoria vía `cached_network_image`
- Invalidación mediante `cacheKey` parameter
- Placeholder y error widgets configurables
- Soporte para imágenes circulares
- Callback `onImageLoaded` para detectar cuando la imagen terminó de cargar

**Constructores**:
- `SmartCachedImage()`: Constructor estándar
- `SmartCachedImage.circle()`: Constructor para imágenes circulares

**Parámetros principales**:
- `imageUrl`: URL de la imagen
- `cacheKey`: Clave de cache para invalidación (opcional)
- `placeholderAsset`: Asset SVG para mostrar mientras carga (opcional)
- `onImageLoaded`: Callback que se ejecuta cuando la imagen terminó de cargar (opcional)

## Uso Básico

### Paso 1: Obtener Cache Key

En tu `State` class, declara una variable para el `cacheKey`:

```dart
class _MyPageState extends State<MyPage> {
  String? _imageCacheKey;
  
  @override
  void initState() {
    super.initState();
    _initializeImageCacheKey();
  }

  void _initializeImageCacheKey() {
    if (imageUrl.isEmpty) {
      _imageCacheKey = null;
      return;
    }

    // Obtener o crear cache key de forma síncrona
    final result = ImageCacheManager.instance.getOrCreateCacheKeySync(
      entityId: entityId,  // ID de la entidad (ej: driver.id, client.id)
      entityType: 'driver', // Tipo de entidad: 'driver', 'client', 'taxi', etc.
    );
    _imageCacheKey = result.$1;
    
    // Guardar si fue recién creado
    if (result.$2) {
      ImageCacheManager.instance.saveCacheKeyIfNeeded(
        entityId: entityId,
        entityType: 'driver',
        cacheKey: _imageCacheKey!,
      );
    }
  }
}
```

### Paso 2: Usar SmartCachedImage

**Uso básico**:

```dart
Widget _buildImage() {
  return SmartCachedImage.circle(
    radius: 80,
    imageUrl: imageUrl.isNotEmpty
        ? "${ApiConfig().baseUrl}/$imageUrl"
        : null,
    cacheKey: _imageCacheKey,
    placeholderAsset: "assets/icons/taxi.svg",
    backgroundColor: colorScheme.onSecondary,
    placeholderColor: colorScheme.onSecondaryContainer,
  );
}
```

**Con indicador de carga** (recomendado para actualizaciones):

```dart
class _MyPageState extends State<MyPage> {
  bool _isImageLoading = false; // Estado para indicador de carga
  
  Widget _buildImage() {
    return Stack(
      children: [
        // Siempre carga la imagen en segundo plano
        SmartCachedImage.circle(
          radius: 80,
          imageUrl: imageUrl.isNotEmpty
              ? "${ApiConfig().baseUrl}/$imageUrl"
              : null,
          cacheKey: _imageCacheKey,
          placeholderAsset: "assets/icons/taxi.svg",
          backgroundColor: colorScheme.onSecondary,
          placeholderColor: colorScheme.onSecondaryContainer,
          onImageLoaded: () {
            // Ocultar indicador cuando la imagen terminó de cargar
            if (mounted && _isImageLoading) {
              setState(() {
                _isImageLoading = false;
              });
            }
          },
        ),
        // Overlay que oculta el placeholder cuando está cargando
        if (_isImageLoading)
          ClipOval(
            child: Container(
              width: 160,
              height: 160,
              color: colorScheme.onSecondary,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
```

## Invalidación de Cache

### Cuándo Invalidar

**⚠️ IMPORTANTE**: Solo invalida el cache cuando la imagen **realmente** cambió. No invalides cuando solo se actualizan otros campos (nombre, teléfono, etc.).

### Cómo Invalidar

Hay dos escenarios principales:

#### Escenario 1: Nueva Imagen Subida

Cuando el usuario sube una nueva imagen (`XFile? _newImage != null`):

```dart
Future<void> _saveProfile() async {
  final response = await _accountService.updateProfile(
    name: _nameController.text,
    image: _newImage, // Nueva imagen subida
  );

  if (response.statusCode == 200) {
    final updatedProfile = Profile.fromJson(jsonDecode(response.body));
    
    // Invalida cache solo si se subió nueva imagen
    if (_newImage != null && updatedProfile.imageUrl.isNotEmpty) {
      final imageUrl = "${ApiConfig().baseUrl}/${updatedProfile.imageUrl}";
      final newCacheKey = await ImageCacheManager.instance.invalidateCache(
        entityId: profile.id,
        entityType: 'driver', // o 'client', 'taxi', etc.
        imageUrl: imageUrl,
      );
      
      if (mounted) {
        setState(() {
          _imageCacheKey = newCacheKey;
          _newImage = null; // Limpiar después de usar
        });
      }
    }
  }
}
```

#### Escenario 2: Imagen Cambió en el Servidor

Cuando la URL de la imagen cambió después de una actualización:

```dart
Future<void> _saveProfile() async {
  // Guardar URL anterior para comparar
  final oldImageUrl = profile.imageUrl;
  
  final response = await _accountService.updateProfile(...);
  
  if (response.statusCode == 200) {
    final updatedProfile = Profile.fromJson(jsonDecode(response.body));
    
    // Detectar si la imagen cambió
    final imageChanged = _newImage != null || oldImageUrl != updatedProfile.imageUrl;
    
      if (imageChanged && updatedProfile.imageUrl.isNotEmpty) {
        final imageUrl = "${ApiConfig().baseUrl}/${updatedProfile.imageUrl}";
        final newCacheKey = await ImageCacheManager.instance.invalidateCache(
          entityId: updatedProfile.id,
          entityType: 'driver',
          imageUrl: imageUrl,
        );
        
        if (mounted) {
          setState(() {
            _imageCacheKey = newCacheKey;
            _isImageLoading = true; // Mostrar indicador mientras descarga
          });
          // onImageLoaded callback ocultará el indicador cuando termine
        }
      }
  }
}
```

## Ejemplos Completos

### Ejemplo 1: Driver Settings (Perfil de Conductor)

```dart
class _DriverSettingsPageState extends State<DriverSettingsPage> {
  final _driver = Driver.fromJson(loggedInUser);
  late Taxi _taxi;
  XFile? _taxiImage;
  String? _imageCacheKey;
  bool _isImageLoading = false; // Indicador de carga para actualizaciones

  @override
  void initState() {
    super.initState();
    _taxi = _driver.taxi;
    _initializeImageCacheKey();
    _saveImageCacheKeyIfNeeded();
  }

  void _initializeImageCacheKey() {
    if (_taxi.imageUrl.isEmpty) {
      _imageCacheKey = null;
      return;
    }

    final result = ImageCacheManager.instance.getOrCreateCacheKeySync(
      entityId: _driver.id,
      entityType: 'driver',
    );
    _imageCacheKey = result.$1;
  }

  Future<void> _saveImageCacheKeyIfNeeded() async {
    if (_taxi.imageUrl.isEmpty || _imageCacheKey == null) {
      return;
    }
    await ImageCacheManager.instance.saveCacheKeyIfNeeded(
      entityId: _driver.id,
      entityType: 'driver',
      cacheKey: _imageCacheKey!,
    );
  }

  Future<void> _savePersonalInfo() async {
    final response = await _accountService.updateDriver(
      _driver.id,
      name: _nameController.text,
      phone: _phoneController.text,
      image: _taxiImage,
    );

    if (response.statusCode == 200) {
      final driver = Driver.fromJson(jsonDecode(response.body));
      final oldImageUrl = _taxi.imageUrl; // Guardar URL anterior
      
      await SessionPrefsManager.instance.save(driver);
      _taxi = driver.taxi;

      // Solo invalidar si la imagen cambió
      final imageChanged = _taxiImage != null || oldImageUrl != _taxi.imageUrl;
      
      if (imageChanged && _taxi.imageUrl.isNotEmpty) {
        final imageUrl = "${ApiConfig().baseUrl}/${_taxi.imageUrl}";
        final newCacheKey = await ImageCacheManager.instance.invalidateCache(
          entityId: _driver.id,
          entityType: 'driver',
          imageUrl: imageUrl,
        );
        
        if (mounted) {
          setState(() {
            _imageCacheKey = newCacheKey;
            _isImageLoading = true; // Mostrar indicador mientras descarga
          });
          // onImageLoaded callback ocultará el indicador cuando termine
        }
      }
      
      setState(() {
        _taxiImage = null;
      });
    }
  }

  Widget _buildCircleImagePicker() {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        // Siempre carga la imagen en segundo plano (incluso cuando muestra loading)
        SmartCachedImage.circle(
          radius: 80,
          imageUrl: _taxi.imageUrl.isNotEmpty
              ? "${ApiConfig().baseUrl}/${_taxi.imageUrl}"
              : null,
          cacheKey: _imageCacheKey,
          placeholderAsset: "assets/icons/taxi.svg",
          backgroundColor: colorScheme.onSecondary,
          placeholderColor: colorScheme.onSecondaryContainer,
          onImageLoaded: () {
            // Ocultar indicador cuando la imagen terminó de cargar
            if (mounted && _isImageLoading) {
              setState(() {
                _isImageLoading = false;
              });
            }
          },
        ),
        // Overlay que oculta el placeholder cuando está cargando nueva imagen
        if (_isImageLoading)
          ClipOval(
            child: Container(
              width: 160,
              height: 160,
              color: colorScheme.onSecondary,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
```

### Ejemplo 2: Client Settings (Perfil de Cliente)

```dart
class _ClientSettingsPageState extends State<ClientSettingsPage> {
  final _client = Client.fromJson(loggedInUser);
  XFile? _profileImage;
  String? _imageCacheKey;
  String _initialProfileImageUrl = '';

  @override
  void initState() {
    super.initState();
    _initialProfileImageUrl = _client.profileImageUrl ?? '';
    _initializeImageCacheKey();
  }

  void _initializeImageCacheKey() {
    if (_initialProfileImageUrl.isEmpty) {
      _imageCacheKey = null;
      return;
    }

    final result = ImageCacheManager.instance.getOrCreateCacheKeySync(
      entityId: _client.id,
      entityType: 'client',
    );
    _imageCacheKey = result.$1;
    
    if (result.$2) {
      ImageCacheManager.instance.saveCacheKeyIfNeeded(
        entityId: _client.id,
        entityType: 'client',
        cacheKey: _imageCacheKey!,
      );
    }
  }

  Future<void> _saveProfile() async {
    final oldImageUrl = _initialProfileImageUrl;
    
    final response = await _accountService.updateClient(
      _client.id,
      name: _nameController.text,
      image: _profileImage,
    );

    if (response.statusCode == 200) {
      final client = Client.fromJson(jsonDecode(response.body));
      await SessionPrefsManager.instance.save(client);
      
      _initialProfileImageUrl = client.profileImageUrl ?? '';
      
      final imageChanged = _profileImage != null || oldImageUrl != _initialProfileImageUrl;
      
      if (imageChanged && _initialProfileImageUrl.isNotEmpty) {
        final imageUrl = "${ApiConfig().baseUrl}/$_initialProfileImageUrl";
        final newCacheKey = await ImageCacheManager.instance.invalidateCache(
          entityId: _client.id,
          entityType: 'client',
          imageUrl: imageUrl,
        );
        
        if (mounted) {
          setState(() {
            _imageCacheKey = newCacheKey;
            _profileImage = null;
          });
        }
      }
    }
  }
}
```

## Indicador de Carga Durante Actualizaciones

Cuando se invalida el cache y se descarga una nueva imagen, es recomendable mostrar un indicador de carga en lugar del placeholder para mejorar la experiencia del usuario.

### Implementación

```dart
class _MyPageState extends State<MyPage> {
  bool _isImageLoading = false;
  
  Future<void> _updateImage() async {
    // Invalidar cache
    final newCacheKey = await ImageCacheManager.instance.invalidateCache(...);
    
    setState(() {
      _imageCacheKey = newCacheKey;
      _isImageLoading = true; // Activar indicador
    });
  }
  
  Widget _buildImage() {
    return Stack(
      children: [
        SmartCachedImage.circle(
          // ... parámetros ...
          onImageLoaded: () {
            // Desactivar indicador cuando termine
            if (mounted && _isImageLoading) {
              setState(() => _isImageLoading = false);
            }
          },
        ),
        // Overlay que oculta el placeholder durante la carga
        if (_isImageLoading)
          ClipOval(
            child: Container(
              width: 160,
              height: 160,
              color: colorScheme.onSecondary,
              child: Center(
                child: CircularProgressIndicator(...),
              ),
            ),
          ),
      ],
    );
  }
}
```

**Nota**: El `SmartCachedImage` siempre se renderiza en segundo plano. El overlay solo oculta el placeholder visualmente, permitiendo que la imagen se cargue mientras se muestra el indicador de carga.

## Mejores Prácticas

### ✅ DO (Hacer)

1. **Siempre inicializa el cacheKey en `initState()`**
   ```dart
   @override
   void initState() {
     super.initState();
     _initializeImageCacheKey();
     _saveImageCacheKeyIfNeeded();
   }
   ```

2. **Usa `getOrCreateCacheKeySync()` para inicialización síncrona**
   ```dart
   final result = ImageCacheManager.instance.getOrCreateCacheKeySync(...);
   ```

3. **Solo invalida cuando la imagen realmente cambió**
   ```dart
   final imageChanged = _newImage != null || oldImageUrl != newImageUrl;
   if (imageChanged) {
     // Invalidar cache
   }
   ```

4. **Guarda el cacheKey si fue recién creado**
   ```dart
   await ImageCacheManager.instance.saveCacheKeyIfNeeded(...);
   ```

5. **Usa tipos de entidad consistentes**
   - `'driver'` para conductores
   - `'client'` para clientes
   - `'taxi'` para taxis
   - etc.

6. **Muestra indicador de carga durante actualizaciones**
   ```dart
   if (imageChanged) {
     setState(() {
       _imageCacheKey = newCacheKey;
       _isImageLoading = true; // Activar indicador
     });
   }
   ```

### ❌ DON'T (No Hacer)

1. **No invalides el cache cuando solo cambian otros campos**
   ```dart
   // ❌ MAL: Invalida aunque solo cambió el nombre
   await _invalidateImageCache();
   
   // ✅ BIEN: Solo invalida si cambió la imagen
   if (imageChanged) {
     await _invalidateImageCache();
   }
   ```

2. **No olvides verificar si `imageUrl` está vacío**
   ```dart
   if (imageUrl.isEmpty) {
     _imageCacheKey = null;
     return;
   }
   ```

3. **No uses async en `initState()` para obtener cacheKey inicial**
   ```dart
   // ❌ MAL: Async en initState
   void initState() {
     _imageCacheKey = await ImageCacheManager.instance.getCacheKey(...);
   }
   
   // ✅ BIEN: Sync en initState
   void initState() {
     _initializeImageCacheKey(); // Método síncrono
   }
   ```

4. **No mezcles diferentes tipos de entidad para la misma imagen**
   ```dart
   // ❌ MAL: Tipo inconsistente
   ImageCacheManager.instance.getCacheKey(entityId: id, entityType: 'driver');
   ImageCacheManager.instance.getCacheKey(entityId: id, entityType: 'taxi');
   
   // ✅ BIEN: Tipo consistente
   ImageCacheManager.instance.getCacheKey(entityId: id, entityType: 'driver');
   ```

## Solución de Problemas

### Problema: La imagen no se actualiza después de subirla

**Solución**: Asegúrate de:
1. Invalidar el cache correctamente
2. Actualizar el `_imageCacheKey` en el estado
3. El widget debe reconstruirse con el nuevo `cacheKey`

```dart
if (imageChanged) {
  final newCacheKey = await ImageCacheManager.instance.invalidateCache(...);
  setState(() {
    _imageCacheKey = newCacheKey; // ✅ Actualizar estado
  });
}
```

### Problema: La imagen hace "loading" cuando solo actualizo el nombre

**Solución**: Solo invalida el cache cuando la imagen cambió:

```dart
// Guarda la URL anterior
final oldImageUrl = profile.imageUrl;

// Actualiza datos
final updatedProfile = ...;

// Compara URLs
final imageChanged = _newImage != null || oldImageUrl != updatedProfile.imageUrl;

// Solo invalida si cambió
if (imageChanged) {
  await _invalidateImageCache();
}
```

### Problema: El cacheKey es null cuando el widget se construye

**Solución**: Usa inicialización síncrona:

```dart
void _initializeImageCacheKey() {
  // ✅ Usa getOrCreateCacheKeySync en lugar de getCacheKey (async)
  final result = ImageCacheManager.instance.getOrCreateCacheKeySync(...);
  _imageCacheKey = result.$1;
}
```

### Problema: La imagen se muestra en blanco después de actualizar

**Solución**: Verifica que:
1. El `imageUrl` no esté vacío
2. El `cacheKey` no sea null
3. El widget se haya reconstruido después de actualizar

```dart
SmartCachedImage.circle(
  imageUrl: imageUrl.isNotEmpty ? fullUrl : null, // ✅ Verificar vacío
  cacheKey: _imageCacheKey, // ✅ No debe ser null si hay imageUrl
  ...
)
```

## Resumen

1. **ImageCacheManager**: Servicio singleton para gestionar cache keys
2. **SmartCachedImage**: Widget para mostrar imágenes con cache inteligente
3. **Invalidación condicional**: Solo invalida cuando la imagen realmente cambió
4. **Inicialización síncrona**: Usa `getOrCreateCacheKeySync()` en `initState()`
5. **Tipos consistentes**: Usa el mismo `entityType` para cada entidad

¿Preguntas o problemas? Revisa los ejemplos o consulta con el equipo de desarrollo.

