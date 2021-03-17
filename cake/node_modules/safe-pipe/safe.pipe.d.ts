import { PipeTransform } from '@angular/core';
import { DomSanitizer, SafeStyle, SafeResourceUrl, SafeScript, SafeHtml, SafeUrl } from '@angular/platform-browser';
export declare class SafePipe implements PipeTransform {
    protected sanitizer: DomSanitizer;
    constructor(sanitizer: DomSanitizer);
    transform(value: string, type: string): SafeHtml | SafeStyle | SafeScript | SafeUrl | SafeResourceUrl;
}
